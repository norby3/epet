class MeasureController < ApplicationController

  def hop
      @hop = Hop.new(params[:hop])
      if !request.remote_ip.blank?
          @hop.ip = request.remote_ip
      end
      if @hop.save
          #render :json => {"foo" => "bar"}
          render :json => @hop
      else
          logger.error("error saving hop")
      end
  end

end
    # 
    # t.string :upid
    # t.string :email
    # t.string :name
    # t.string :cordova
    # t.string :platform
    # t.string :uuid
    # t.string :version
    # t.string :page
    # t.string :prev_page
    # t.string :ip
    # t.string :connection
    # t.string :network
    # t.string :timestamp
