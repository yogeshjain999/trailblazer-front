module ::Guard
  # https://github.com/guard/guard/wiki/Create-a-guard
  class Torture < Plugin
  end
end
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"
guard :torture do
  puts "here comes full site compile"
  pages = {"section/rails/cells.md.erb" => 99}

  # This runs the modified test
  watch /section\/(.*)/ do |m|
    `echo #{m[0]}`
    puts pages[m[0]]
  end
  # # This calls the plugin with a new file name - which may not even exist
  # watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }

  # # This call the plugin with the 'test' parameter - see Guard::Minitest docs
  # # for information in how it finds/choose files in the given 'test' directory
  # watch(%r{^test/test_helper\.rb$})      { 'test' }
end
