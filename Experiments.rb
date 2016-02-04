require 'active_record'
require 'sqlite3'
require 'logger'
require 'object_tracker'
require 'amb'
require_relative 'app/models/user'
require_relative 'app/models/micropost'
require_relative 'analysis/symbolics/symbolics'

class Logger
  def error(*args)
    puts caller
    puts "Error raised with #{args}"
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

A = Class.new {include Amb}.new

=begin
x = A.choose(true,false)
y = A.choose(true,false)

A.assert(!x && !y)

puts "#{x} and #{y}"
=end

class User
  extend ObjectTracker
  def initialize(attrs={})
    super
    puts "User created with #{attrs}"
  end
  def real_nil?
    if @is_nil.nil? then
      @is_nil = A.choose(true,false)
      #puts "******* amb returned #{@is_nil}"
    end
    @is_nil
  end

  def nil?
    real_nil?
  end

  def real_blank?
    if @is_blank.nil? then
      val = A.choose(false,true)
      #puts "******* Current value of @is_blank = #{@is_blank}"
      @is_blank = val
      puts "[#{self}]******* amb returned #{@is_blank}"
    end
    @is_blank
  end

  def blank?
    real_blank?
  end

  def method_missing(name, *args, &blk)
    puts "User##{name} method is missing"
    #puts caller
  end
=begin
  def respond_to? *args
    puts "Called User#respond_to? with #{args}"
    x = super
    puts "Returning #{x}"
    x
  end
=end
end

class Micropost
  extend ObjectTracker
=begin
  def allocate
    puts "ARS = #{$ARS}"
    x = super
    $ARS.push x
    x
  end
=end
  def initialize(attrs={})
    super
    $ARS.push(self)
    puts "Micropost initialized with #{attrs}"
  end
  def do_validate
    self.perform_validations
  end
  def send(*attr)
    #puts "Sent for attr: #{attr}"
    x = super
    x
  end

  def instrument(res)
    puts "User::allocate returned #{res}"
  end
end

$instrument = lambda {|res| puts "Res is #{res}"}

#puts ENV.to_hash.to_yaml

#Micropost.track_all!
$ARS = []
User.track_with(:allocate => lambda { |i| i})
Micropost.track_with(:allocate => lambda { |i| i})
#puts SymbolicUserId.methods
#SymbolicUserId.track_all!
sym_uid = SymbolicUntyped.new("post.user_id")#.extend ObjectTracker
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