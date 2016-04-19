module Log
  def info(text)
    puts "\e[#{34}m#{text}\e[0m"
  end

  def error(text)
    puts "\e[#{31}m#{text}\e[0m"
  end

  def success(text)
    puts "\e[#{32}m#{text}\e[0m"
  end
end
