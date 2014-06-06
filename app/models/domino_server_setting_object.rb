class DominoServerSettingObject < RailsSettings::SettingObject
  #todo transform to has_password :password_name_field, :key
  def password
    puts "password is encripted !!"
    super
  end
  def decrypted_password
    decrypted_value = Encryptor.decrypt(:value => self.password, :key => secret_key)
    puts "password is decrypted !!"
    decrypted_value
  end

  def password=(value)
    encrypted_value = Encryptor.encrypt(:value => value, :key => secret_key) unless value.blank?
    super(encrypted_value )
  end
  private
  def secret_key
    "dasd asdas asfdfa fa wereaw fsdaf sdf wedsff weraf"
  end

end