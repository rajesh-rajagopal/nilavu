class User

  attr_accessor :id
  attr_accessor :email
  attr_accessor :password
  attr_accessor :api_key
  attr_accessor :team
  attr_accessor :firstname
  attr_accessor :lastname
  attr_accessor :authority
  attr_accessor :verified
  attr_accessor :password_reset_key
  attr_accessor :password_reset_sent_at
  attr_accessor :created_at
  attr_accessor :errors
  attr_accessor :phone
  attr_accessor :unread_notifications
  attr_accessor :unread_total_notifications

  ADMIN = 'admin'.freeze

  def self.max_password_length
    200
  end

  def self.new_from_params(params)
    user = User.new
    params.symbolize_keys!
    user.email = params[:email]
    user.team  = params[:team]
    user.api_key = params[:api_key]
    user.firstname = params[:firstname]
    user.lastname = params[:lastname]
    user.phone = params[:phone]
    user.password = params[:password]
    user.password_reset_key = params[:password_reset_key]
    user.password_reset_sent_at = params[:password_reset_sent_at]
    user.created_at = params[:created_at]
    user
  end

  def self.suggest_firstname(email)
    return "" if email.blank?
    email[/\A[^@]+/].tr(".", " ").titleize
  end

  def find_by_email
    ensure_password_is_hashed
    if to_hash[:email].include?('@')
      find_by_password
    end
  end

  def save
    ensure_password_is_hashed
    Api::Accounts.new.save(to_hash)
  end

  def update
    Api::Accounts.new.update(update_hash)
  end

  def reset
    Api::Accounts.new.reset(to_hash)
  end

  def repassword
    Api::Accounts.new.repassword(update_hash)
  end

  def email_available?
    find_by_email
  rescue Nilavu::NotFound => e
    false
  end

  def password=(password)
    unless password.blank?
      @raw_password = password
    end
  end

  # Indicate that this is NOT a passwordless account for the purposes of validation
  def password_required!
    @password_required = true
  end

  def password_required?
    !!@password_required
  end

  def has_password?
    password_hash.present?
  end

  def confirm_password?(password)
    return false unless password && @raw_password
    password == password_hash(@raw_password)
  end

  def email_confirmed?
    true
  end

  def ensure_password_is_hashed
    if @raw_password
      self.password = hash_password(@raw_password)
    end
  end

  def hash_password(password)
    raise "password is too long" if password.size > User.max_password_length
    Base64.strict_encode64(password)
  end

  def password_hash(password)
    Base64.strict_decode64(password)
  end

  def admin?
    if authority
      return authority.include?("admin")
    end
    false
  end

  def staff?
    admin? && Rails.env.development?
  end

  def org_id
    team.id if team
  end

  def to_hash
    {:email => @email,
      :api_key => @api_key,
      :password => @raw_password,
      :username => User.suggest_firstname(@email),
      :first_name =>@firstname,
      :last_name => @lastname,
      :phone => @phone,
      :createdAt =>@created_at
    }
  end

  def update_hash
    {:email => @email,
      :api_key => @api_key,
      :password => ensure_password_is_hashed,
      :username => User.suggest_firstname(@email),
      :first_name => @firstname,
      :last_name => @lastname,
      :password_reset_key => @password_reset_key,
      :phone => @phone,
      :createdAt =>@created_at
    }
  end

  def reload
    @unread_notifications = nil
    @unread_total_notifications = nil
#    super
  end

  def publish_notifications_state
    # publish last notification json with the message so we
    # can apply an update
  end

  private

  def parms_using_password
    {:email =>@email, :password => @raw_password }
  end

  def find_by_password
    user = Api::Accounts.new.where(parms_using_password)
    if user
      return User.new_from_params(user.to_hash)
    end
  end

  def visit_record_for(date)
    #Schedule.defer "send an audit event login or logoff, date" do
    #pump using a time expirable key
    #events.last_seen_at(visited_at: date)
    #end
  end
end
