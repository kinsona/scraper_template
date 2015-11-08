require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'json'

puts "Enter NYT recipe URL:"
url = gets.chomp

recipe = {}

agent = Mechanize.new

page = agent.get(url)
recipe_section = page.search('.recipe') || page

def recipe_search(node, query, attribute_name)
  result = node.search(query)
  if result.empty?
    return nil
  else
    return result.attribute(attribute_name)
  end
end


recipe['title'] = recipe_search(recipe_section, "h1.recipe-title", "data-name")

recipe['author'] = recipe_search(recipe_section, '.author', 'data-author')



# use this one instead of the SEO one in the header b/c it's large not jumbo
recipe['image_url'] = recipe_search(recipe_section, '.recipe-intro img', 'src')
# 'data-seo-image-url'


def parse(list_node)
  output = []
  list_node.children.each do |child|
    # this is the 'squish' method in Rails'
    child_text = child.text.strip.gsub(/\s+/, " ")
    output << child_text unless child_text.empty?
  end
  return output
end



raw_body = recipe_section.search('ol.recipe-steps')
recipe['body'] = parse(raw_body)


# this is on the page twice, but second one empty
# are there recipes where it's got data both times?
raw_ingredients = recipe_section.search('ul.recipe-ingredients')
recipe['ingredients'] = parse(raw_ingredients)




File.open('output.txt', 'w') do |file|
  file.write recipe.to_json
end
