require "openssl"
require "base64"

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  private

  def authorize_request
    # サーバートークン認証が既に成功している場合はスキップ
    return if @skip_auth0_check || (respond_to?(:server_token_authenticated?) && server_token_authenticated?)
    
    token = request.headers["Authorization"]&.split(" ")&.last

    if token
      header = JWT.decode(token, nil, false).last

      jwks = jwks_loader

      key_data = jwks.find { |k| k[:kid] == header["kid"] }
      # If key not found, refresh JWKS once (in case of rotation) and retry
      if key_data.nil?
        Rails.logger.info("JWKS key not found for kid=#{header['kid']}, refreshing JWKS and retrying")
        # force reload by clearing memo and calling loader again
        @jwks = nil
        jwks = jwks_loader
        key_data = jwks.find { |k| k[:kid] == header["kid"] }
      end
      unless key_data
        available_kids = jwks.map { |k| k[:kid] }
        Rails.logger.warn("JWT kid=#{header['kid']} not found in JWKS; available kids=#{available_kids.inspect}")
        raise JWT::DecodeError, "Key not found (kid=#{header['kid']})"
      end

      cert_text = "-----BEGIN CERTIFICATE-----\n#{key_data[:x5c].first}\n-----END CERTIFICATE-----"
      certificate = OpenSSL::X509::Certificate.new(cert_text)
      public_key = certificate.public_key

      decoded_token = JWT.decode(token, public_key, true, { algorithms: [ "RS256" ] })
      payload = decoded_token[0]

      if payload["exp"] && Time.at(payload["exp"]) < Time.now
        render json: { error: "Token has expired" }, status: :unauthorized
      else
        @current_user = payload
      end
      @current_user = payload
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  rescue JWT::DecodeError => e
    render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
  end

  def jwks_loader
    @jwks ||= begin
      jwks_uri = ENV["AUTH0_JWKS_URI"]
      unless jwks_uri && jwks_uri.is_a?(String) && !jwks_uri.empty?
        # Try to construct from AUTH0_DOMAIN if available
        domain = ENV["AUTH0_DOMAIN"]
        if domain && domain.is_a?(String) && !domain.empty?
          jwks_uri = "https://#{domain}/.well-known/jwks.json"
        else
          raise "AUTH0_JWKS_URI or AUTH0_DOMAIN must be set for JWT verification"
        end
      end

      begin
        uri = URI(jwks_uri)
      rescue => e
        raise ArgumentError, "Invalid JWKS URI: #{e.message}"
      end

      begin
        jwks_raw = Net::HTTP.get(uri)
      rescue => e
        raise "Failed to fetch JWKS: #{e.message}"
      end

      jwks_keys = JSON.parse(jwks_raw)["keys"]

      jwks_keys.map do |key|
        {
          kid: key["kid"],
          x5c: key["x5c"]
        }
      end
    end
  end

  def current_user_id
    @current_user["sub"] # Auth0 のユーザーID
  end

  def current_user_email
    @current_user["email"]
  end

  def current_user_name
    @current_user["name"] || "Unknown"
  end
end
