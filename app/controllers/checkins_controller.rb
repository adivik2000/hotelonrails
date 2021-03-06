class CheckinsController < ApplicationController
  before_filter :authenticate_user!

  # GET /checkins
  # GET /checkins.xml
  def index
    @checkins = Checkin.where("status is NULL")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkins }
    end
  end

  # GET /checkins/1
  # GET /checkins/1.xml
  def show
    @checkin = Checkin.find(params[:id])

    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.xml  { render :xml => @checkin }
    end
  end

  # GET /checkins/new
  # GET /checkins/new.xml
  def new
    @checkin = Checkin.new
    @rooms = Room.where("status is NULL");
    @company = Company.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkin }
    end
  end

  # GET /checkins/1/edit
  def edit
    @checkin = Checkin.find(params[:id])
    @checkin.status = "Checked Out"
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /checkins
  # POST /checkins.xml
  def create
    @checkin = Checkin.new(params[:checkin])
    respond_to do |format|
      if not params[:guest].nil?
        if @checkin.save 
          params[:payment][:checkin_id] = @checkin.id
          if(params[:payment][:amount] != 0)
            @payment = Payment.new(params[:payment])
            @payment.save!
          end
          1.upto(Room.all.length) do |i|
            if not params["room#{i.to_s}"].nil?
              params["room#{i.to_s}"][:checkin_id] = @checkin.id
              line_item = LineItem.new(params["room#{i.to_s}"])
              line_item.save!
            end
          end
          params[:guest].each do |key,value|
            arr = value.split(/#/)
            guest = Guest.new
            if arr[0] != "" || arr[1] != ""
              guest.FirstName = arr[0]
              guest.LastName = arr[1]
              guest.save!
              @checkin.guests << guest
            end
          end
          format.html { redirect_to(user_root_url, :notice => 'Checkin was successfully created.') }
          format.xml  { render :xml => @checkin, :status => :created, :location => @checkin }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @checkin.errors, :status => :unprocessable_entity }
        end
      else
          format.html { redirect_to :action => "new",:notice => "Please add guests" }
      end
 

    end
  end

  # PUT /checkins/1
  # PUT /checkins/1.xml
  def update
    @checkin = Checkin.find(params[:id])

    respond_to do |format|
      if @checkin.update_attributes(params[:checkin])
        if not @checkin.status.nil?
          @checkin.line_items.each do |li|
            li.room.update_attribute('status',nil)
            li.room.save!
          end
        end
        format.html { redirect_to(user_root_url, :notice => 'Checkin was successfully updated.') }
        format.js { }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkins/1
  # DELETE /checkins/1.xml
  def destroy
    @checkin = Checkin.find(params[:id])
    @checkin.destroy

    respond_to do |format|
      format.html { redirect_to(checkins_url) }
      format.xml  { head :ok }
    end
  end

  def checkout
    @checkin = Checkin.find(params[:id])
    @title = "Print Invoice"
    respond_to do |format|
      format.html { render :layout => "print"}
    end
  end
 
  def split_room
    line_item = LineItem.find(params[:splitroom_line_item_id].sub(/\D+/,''))
    checkin = Checkin.new
    checkin.company = line_item.checkin.company if not line_item.checkin.company.nil?
    checkin.save!
    checkin.guests << line_item.checkin.guests
    line_item.checkin.service_items.each do |si|
      if si.room_id == line_item.room_id
        si.checkin = checkin
        si.save!
      end
    end
    line_item.checkin = checkin
    line_item.save!
    respond_to do |format|
      format.html {
        flash[:notice] = "Splitted Room as a new checkin successfully"
        redirect_to user_root_url
      }
    end
  end

end
