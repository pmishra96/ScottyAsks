require 'mechanize'
require "httparty"


class DirectoryAPI

    def initialize
        @token = 'nJ+gXjL+ZpbdhuNR700AT7H3AEQ5r2/zB1+8DSWAl/Y='
        @base_url = 'https://directory.andrew.cmu.edu/'
        @mechanize = Mechanize.new
    end

    # get scraped page for andrewid from cmu directory
    def get_user_page(andrewid)
        
        @token = 'nJ+gXjL+ZpbdhuNR700AT7H3AEQ5r2/zB1+8DSWAl/Y='
        @mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        page = @mechanize.get(@base_url)
        form = page.forms.first

        # populate form fields
        form.fields[0].value =  @token
        form.fields[1].value = andrewid

        # get the page and return
        page = form.submit
        return page
    end

    # get fullname from andrewid
    def get_fullname(andrewid)
        page = get_user_page(andrewid)
        return page.search('h1')[1].text.split( "(" )[0].strip
        # response = {}
        # begin
        #     response = Hash[HTTParty.get("http://apis.scottylabs.org/directory/v1/andrewID/#{andrewid}", timeout:5)]
        # rescue Net::ReadTimeout, Net::OpenTimeout => e
        #     response = {"first_name"=>andrewid, "last_name"=>"student"}
        # end
        # return "#{response["first_name"]} #{response["last_name"]}"
    end

    # check if cmu directory has page for andrewid
    def verify_user_exists(andrewid)
        return (!get_fullname(andrewid).empty? or !get_fullname(andrewid).nil?)
        # found = false
        # begin
        #     response = Hash[HTTParty.get("http://apis.scottylabs.org/directory/v1/andrewID/#{andrewid}", timeout:5)]
        #     found = response["andrewID"] == andrewid
        # rescue Net::ReadTimeout, Net::OpenTimeout => e
        # end
        # return found
    end

end
