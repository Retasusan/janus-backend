class Auth0Service
  include HTTParty
  
  def initialize
    @domain = ENV['AUTH0_DOMAIN']
    @client_id = ENV['AUTH0_CLIENT_ID']
    @client_secret = ENV['AUTH0_CLIENT_SECRET']
    @management_token = nil
    @token_expires_at = nil
    
    raise "Auth0 configuration missing" unless @domain && @client_id && @client_secret
  end

  def get_user(user_id)
    token = get_management_token
    unless token
      Rails.logger.warn "No management token available, using fallback for user #{user_id}"
      return get_fallback_user_info(user_id)
    end

    response = HTTParty.get(
      "https://#{@domain}/api/v2/users/#{CGI.escape(user_id)}",
      headers: {
        'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/json'
      }
    )

    if response.success?
      user_data = response.parsed_response
      Rails.logger.info "Auth0 user data for #{user_id}: #{user_data.inspect}"
      
      {
        name: extract_display_name(user_data),
        email: user_data['email'],
        picture: user_data['picture'],
        nickname: user_data['nickname'],
        given_name: user_data['given_name'],
        family_name: user_data['family_name']
      }
    else
      Rails.logger.error "Failed to get user from Auth0: #{response.code} - #{response.body}"
      get_fallback_user_info(user_id)
    end
  rescue => e
    Rails.logger.error "Error getting user from Auth0: #{e.message}"
    get_fallback_user_info(user_id)
  end

  def get_users(user_ids)
    return {} if user_ids.empty?
    
    token = get_management_token
    unless token
      Rails.logger.warn "No management token available, using fallback for users"
      return user_ids.each_with_object({}) { |id, hash| hash[id] = get_fallback_user_info(id) }
    end

    # Auth0 Management APIは複数ユーザーの一括取得をサポートしていないため、
    # 個別に取得するか、検索クエリを使用する
    users = {}
    
    user_ids.each_slice(10) do |batch_ids|
      # 検索クエリを使用して複数ユーザーを取得
      query = batch_ids.map { |id| "user_id:\"#{id}\"" }.join(' OR ')
      
      response = HTTParty.get(
        "https://#{@domain}/api/v2/users",
        query: {
          q: query,
          search_engine: 'v3'
        },
        headers: {
          'Authorization' => "Bearer #{token}",
          'Content-Type' => 'application/json'
        }
      )

      if response.success?
        response.parsed_response.each do |user_data|
          users[user_data['user_id']] = {
            name: extract_display_name(user_data),
            email: user_data['email'],
            picture: user_data['picture'],
            nickname: user_data['nickname'],
            given_name: user_data['given_name'],
            family_name: user_data['family_name']
          }
        end
      else
        Rails.logger.error "Failed to get users batch from Auth0: #{response.code} - #{response.body}"
        # フォールバックとして、取得できなかったユーザーの情報を生成
        batch_ids.each do |id|
          users[id] ||= get_fallback_user_info(id)
        end
      end
    end

    # 取得できなかったユーザーにフォールバック情報を設定
    user_ids.each do |id|
      users[id] ||= get_fallback_user_info(id)
    end

    users
  rescue => e
    Rails.logger.error "Error getting users from Auth0: #{e.message}"
    user_ids.each_with_object({}) { |id, hash| hash[id] = get_fallback_user_info(id) }
  end

  private

  def get_management_token
    # トークンがまだ有効な場合は再利用
    if @management_token && @token_expires_at && Time.current < @token_expires_at
      return @management_token
    end

    response = HTTParty.post(
      "https://#{@domain}/oauth/token",
      body: "grant_type=client_credentials&client_id=#{@client_id}&client_secret=#{@client_secret}&audience=https://#{@domain}/api/v2/",
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    )

    if response.success?
      token_data = response.parsed_response
      @management_token = token_data['access_token']
      # トークンの有効期限を設定（少し余裕を持たせる）
      @token_expires_at = Time.current + (token_data['expires_in'] - 300).seconds
      @management_token
    else
      Rails.logger.error "Failed to get Auth0 management token: #{response.code} - #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Error getting Auth0 management token: #{e.message}"
    nil
  end

  def extract_display_name(user_data)
    # 優先順位に従ってユーザー名を決定
    # 1. nickname (多くの場合、ユーザーが設定した表示名)
    # 2. given_name + family_name の組み合わせ
    # 3. name フィールド
    # 4. username フィールド
    # 5. メールアドレスから推測
    
    Rails.logger.info "Extracting display name from: nickname=#{user_data['nickname']}, given_name=#{user_data['given_name']}, family_name=#{user_data['family_name']}, name=#{user_data['name']}, username=#{user_data['username']}, email=#{user_data['email']}"
    
    return user_data['nickname'] if user_data['nickname'].present?
    
    if user_data['given_name'].present? || user_data['family_name'].present?
      full_name = [user_data['given_name'], user_data['family_name']].compact.join(' ')
      return full_name if full_name.present?
    end
    
    return user_data['name'] if user_data['name'].present?
    return user_data['username'] if user_data['username'].present?
    
    # 最後の手段としてメールアドレスから推測
    extract_name_from_email(user_data['email'])
  end

  def extract_name_from_email(email)
    return "Unknown User" unless email
    
    # メールアドレスから名前を推測
    local_part = email.split('@').first
    local_part.split(/[._-]/).map(&:capitalize).join(' ')
  end

  def get_fallback_user_info(user_id)
    # Auth0 APIが利用できない場合のフォールバック
    provider_info = user_id.split('|')
    provider = provider_info[0]
    id_part = provider_info[1]
    
    case provider
    when 'google-oauth2'
      name = "Google User #{id_part[-4..-1]}"
    when 'github'
      name = "GitHub User #{id_part[-4..-1]}"
    when 'auth0'
      name = "User #{id_part}"
    else
      name = "User #{user_id[-4..-1]}"
    end
    
    {
      name: name,
      email: nil,
      picture: nil,
      nickname: nil,
      given_name: nil,
      family_name: nil
    }
  rescue => e
    Rails.logger.error "Failed to generate fallback user info for #{user_id}: #{e.message}"
    {
      name: "Unknown User",
      email: nil,
      picture: nil,
      nickname: nil,
      given_name: nil,
      family_name: nil
    }
  end
end