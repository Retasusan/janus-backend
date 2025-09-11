Rails.application.config.after_initialize do
  if Rails.env.development?
    Rails.application.routes.default_url_options[:host] = ENV.fetch("BACKEND_HOST", "http://localhost:8000")
  end
end
