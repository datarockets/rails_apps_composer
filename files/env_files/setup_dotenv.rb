  unless File.exist?(".env")
    cp ".env.sample", ".env"
  end
