class Affiliation
  include MongoMapper::Document

  key :confirmed_at,       Time, :default => nil
  key :user_id,            String
  key :university_id,      ObjectId
  key :email,              String, :limit => 40, :default => nil
  key :confirmation_token, String, :index => true

  belongs_to :university
  belongs_to :user
  
  validates_true_for        :email, :logic => lambda {
                              (self.email =~ self.university.email_regexp) != nil
				            }
				            
  validates_uniqueness_of   :email
  validates_presence_of     :email
  
  before_create             :generate_confirmation_token
  after_create              :send_confirmation

  # stolen from devise (TODO place this somewhere common to affiliation
  #                                                      and invitation)
  def self.generate_token
    loop do
      token = ActiveSupport::SecureRandom.base64(15).tr('+/=', '-_ ').strip.
        delete("\n")
      break token unless self.where(:confirmation_token => token).count > 0
    end
  end

  def generate_confirmation_token
    self.confirmation_token = nil
    self.confirmation_token = self.class.generate_token
  end

  def generate_confirmation_token!
    generate_confirmation_token && save(:validate => false)
  end
  #######
  
  def send_confirmation
    if self.university.open_for_signup
      debugger
      generate_confirmation_token! if self.confirmation_token.nil?
      Notifier.signup(self).deliver
    else
      Notifier.closed_for_signup(self).deliver
    end
  end
  
  def self.resend_confirmation(email)
    where(:email=>email).first.send_confirmation
  end
end
