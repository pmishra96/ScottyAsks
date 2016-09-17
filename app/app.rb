require "sinatra/base"
require "sinatra/assetpack"
require 'sinatra-websocket'
require 'rack-flash'
require 'pony'
require 'json'
require 'erb'

class Check < Sinatra::Base

  configure :production, :development do
    # logging
    enable :logging
    # views
    Tilt.register(Tilt::ERBTemplate, 'html.erb')
    #assets
    register Sinatra::AssetPack
    # persistence
    enable :sessions
    # flash for views
    use Rack::Flash
    # sockets
    set :sockets, []
    #email
    Pony.options = { 
      :from => 'check.cmu.notify@gmail.com', 
      :via => :smtp, 
      :via_options => { 
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'check.cmu.notify',
        :password             => ENV["CHECKMAILPASS"],
        :authentication       => :plain, 
        :domain               => "localhost.localdomain" 
      } 
    }
  end

  # asset setup
  assets do
    # stylesheets
    serve '/css', :from => 'assets/css'
    css :application, [
      '/css/uikit.css',
    ]
    # scripts
    serve '/js', :from => 'assets/js'
    js :application, [
      '/js/uikit.min.js',
      '/js/components/autocomplete*'
    ]
    js :event, [
      '/js/event.js'
    ]
    js :event_form, [
      '/js/components/datepicker*',
      '/js/components/timepicker*',
    ]
    js :designate_organizers, [
      '/js/designate_organizers*'
    ]
    # images
    serve '/img', from: 'assets/img'
    # fonts
    serve '/fonts', from: 'assets/fonts'
    # compression
    css_compression :sass
    js_compression :jsmin
  end


  helpers do
    def bootstrap_class_for flash_type
      case flash_type
        when :success
          "uk-alert-success"
        when :error
          "uk-alert-danger"
        when :alert
          "uk-alert-warning"
        when :notice
          "uk-alert-info"
        else
          flash_type.to_s
      end
    end

    def error_messages_for obj
      msg = ""
      obj.errors.each do |error|
        msg += "#{error[0] if error.is_a? Array}\n"
      end
      return msg.strip
    end

    def uk_badge_for event
      if event.public
        return "uk-badge-success"
      else
        return "uk-badge-warning"
      end
    end


    # build emails from views/mail
    # def build_email(template, locals)
    #    template_path = File.open(File.join("views/mail"), template)
    #    rhtml = ERB.new(template_path)

    # end

    

    # ex. if can?(@user, :read, @event)
    # :read => only look at stuff
    # :modify => non-destructive modification
    # :manage => administrative, possibly destructive
    def can?(user, actions, event)
      if event.nil? then raise "must specify user and event" end
      permitted = []
      actions = [] << actions unless actions.is_a?(Array)
      # if the event is public, anonymous users can :read
      if user.nil?
        permitted = [:read] if event.public
      else
        if event.attendees.include? user then permitted = [:read] end
        if event.organizers.include? user then permitted = [:read, :modify] end
        if event.creator == user then permitted = [:read, :modify, :manage] end
      end
      actions.each do |action|
        unless permitted.include? action
          return false
        end
      end
      return true
    end

  end
end

# defime blank helper
class Object
  def blank?
    if self.nil? then return true end
    if self.is_a? String then return self.empty? end
    return false
  end
end

require_relative 'models'
require_relative 'routes'