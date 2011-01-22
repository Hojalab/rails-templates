remove_file "README"
remove_file "doc/"
remove_file "public/index.html"
remove_file "public/images/rails.png"
remove_file "config/database.yml"
run "echo 'config/database.yml' >> .gitignore"

# cleanup gemfile, by removing all commented lines
gsub_file "Gemfile", /#.*\n/, "\n"
gsub_file "Gemfile", /\n+/, "\n"

application do
  (" " * 2) + "config.generators do |generator|\n" +
  (" " * 4) + "end\n"
end
