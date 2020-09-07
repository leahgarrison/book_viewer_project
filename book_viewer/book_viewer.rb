require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @contents = File.readlines("data/toc.txt")

  erb :home
end

get "/chapters/:number" do 
  number = params[:number].to_i
  chapter_name = File.readlines("data/toc.txt")[number-1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end 

not_found do
  redirect "/"
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end


helpers do # formats the chapter into paragraphs
  def in_paragraphs(chapter)
     chapter_paragraphs = chapter.split(/\n\n/)
     chapter_paragraphs.each_with_index.map do |index, text|
       "<p id=paragraph#{index}>#{text}</p>"
     end.join   
  end 

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end 




# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end




