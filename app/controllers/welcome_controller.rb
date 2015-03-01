class WelcomeController < ApplicationController
  def index
    @welcome = Note.create(body: %w( foo bar baz ).sample)
    render text: "There are #{Note.count} notes. The last note is: #{Note.last.body}"
  end
end
