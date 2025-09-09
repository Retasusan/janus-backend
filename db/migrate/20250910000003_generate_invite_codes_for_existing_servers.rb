class GenerateInviteCodesForExistingServers < ActiveRecord::Migration[8.0]
  def up
    Server.where(invite_code: nil).find_each do |server|
      server.update!(invite_code: generate_unique_invite_code)
    end
  end

  def down
    # 既存のサーバーの招待コードをnilに戻す
    Server.update_all(invite_code: nil)
  end

  private

  def generate_unique_invite_code
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless Server.exists?(invite_code: code)
    end
  end
end
