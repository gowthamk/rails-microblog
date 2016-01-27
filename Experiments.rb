require 'active_record'
require 'sqlite3'
require 'logger'
require 'object_tracker'
require_relative 'app/models/user'
require_relative 'app/models/micropost'

class Logger
  def error(progname = nil)
    puts caller
    yield
  end
end
my_logger = Logger.new('log/experiments.log')
my_logger.level= Logger::DEBUG
ActiveRecord::Base.logger = my_logger
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])

=begin
usr = User.new
usr.id="sym_id"
usr.name="sym_name"
usr.email="sym_email"
usr.admin="sym_admin"
usr.remember_token="sym_remember_token"
usr.password_digest="sym_password_digest"
#
=end
# usr.save


class Micropost
  extend ObjectTracker
  def do_validate
    self.perform_validations
  end
  def send(*attr)
    #puts "Sent for attr: #{attr}"
    x = super
    x
  end
end

class SymbolicUserId
  #extend ObjectTracker
  def initialize
    @number = :sym_number
  end
  def id
    self
  end
  def quoted_id
    self
  end
  def to_s
    "sym_user_id"
  end
  def to_ary
    [self]
  end
  def == other
    puts "Asked if equal to #{other}"
    x = super
    puts "Returning #{x}"
  end
  def !
    puts "Called !"
    x = super
    puts "Returning #{x}"
  end
  def respond_to? *args
    puts "Called respond_to? with #{args}"
    x = super
    puts "Returning #{x}"
    x
  end
  def method_missing(name, *args, &blk)
    puts "#{name} method is missing"
  end
  def to_i(*args)
    puts "to_i called with args=#{args}"
    self
  end
end

#Micropost.track_all!
#puts SymbolicUserId.methods
#SymbolicUserId.track_all!
sym_uid = SymbolicUserId.new#.extend ObjectTracker
#sym_uid.track_all!

post = Micropost.new
# post.id does not matter. System creates a new id.
post.id=:sym_id
post.content=:sym_content
# post.user_id is most important.
post.user_id=sym_uid
post.created_at=:sym_created_at
post.updated_at=:sym_updated_at
#post.do_validate
# Until this point, whatever we wrote are retained.
post.save
puts post