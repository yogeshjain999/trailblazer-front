require_relative "../../config/environment"

namespace :site do
  task :render do
    Cms::Render.()
  end

  task :produce_pages do
    Cms::Render.()
  end

  task :deploy do

    FileUtils.chdir Rails.application.root do
      puts "=== precompile assets"
      system("RAILS_ENV=production rails assets:precompile") # copy assets to public/assets with fingerprints.

      puts "=== compile site"
      # Cms::Render.() # for some reasons, fingerprints are set? # render to {public/}
      system("RAILS_ENV=production rails site:produce_pages")

      system("rm -r dist/")
      system("cp -R public dist")

      # puts "== Creating public/dist =="

      puts "=== Commiting dist/"
      commit_message = "Publishing dist/"
      system("git add dist && git commit -m '#{commit_message}'")

      current_branch = `git rev-parse --abbrev-ref HEAD`
      puts "=== Pushing changes to #{current_branch}"
      system("git push origin #{current_branch}")
    end

  end
end
