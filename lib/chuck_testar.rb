require 'rspec/core/formatters/base_text_formatter'
require 'notifications/growl'

module Portable
  def self.platform
    if RbConfig::CONFIG['host_os'] =~ /mswin|windows|cygwin/i
      'windows'
    elsif RbConfig::CONFIG['host_os'] =~ /darwin/
      'osx'
    else
      'linux'
    end
  end
end

class ChuckTestar < RSpec::Core::Formatters::BaseTextFormatter
  def icon(name)
    File.join(File.dirname(__FILE__), '../assets', name)
  end

  def notify(text, icon_filename)
    GrowlNotify.normal({
      :title => 'RSpec',
      :description => text,
      :icon => icon(icon_filename)
    })
  end

  def say(text)
    if Portable.platform == 'linux'
      `echo "#{text}" | espeak`
    elsif Portable.platform == 'osx'
      `say "#{text}"`
    end
  end

  def notify_with_voice!(text, icon_filename)
    notify(text, icon_filename)
    say(text)
  end

  def delay(seconds)
    sleep(seconds)
  end

  def start(example_count)
    super(example_count)
    output.print green('Y')
  end

  def stop
    output.print green('p')
    output.print green("\n\nYour tests pass!\n")
    notify_with_voice!('Your tests pass', 'chuck-normal.png')
    delay(2)
    if @failed_examples.length > 0
      output.print magenta("\n\nNope! It's just Chuck Testa!")
      notify_with_voice!("Nope! It\'s just Chuck Testa!", 'chuck-nope.png')
      delay(1)
    end
  end

  def example_passed(example)
    super(example)
    output.print green('e')
  end

  def example_pending(example)
    super(example)
    output.print green('e')
  end

  def example_failed(example)
    super(example)
    output.print green('e')
  end

  def start_dump
    super()
    output.puts
  end
end

