class Room < ActiveRecord::Base
  belongs_to :room_type
  has_many :line_items
  cattr_reader :per_page
  @@per_page = 12
  named_scope :available,{:conditions => "status is NULL"}

  def roomtype
    return number + " - " + room_type.name + " # " + room_type.baserate.to_s
  end


end
