  def env_sample_vars
    File.read('.env.sample').each_line.inject({}) do |variables, line|
      variable = line.split('=')[0]
      variables.merge({variable => line})
    end
  end

  def try_to_add_new_env_vars
    env_file = File.read('.env')

    File.open('.env', 'a') do |file|
      env_sample_vars.each do |var_name, var_definition|
        file << var_definition unless env_file.include?(var_name)
      end
    end
  end

  if File.exist?(".env")
    try_to_add_new_env_vars
  else
    cp ".env.sample", ".env"
  end
