module SalesForce
  class ApiGet
    def initialize(user_session, api_path, api_params = {})
      @user_session = user_session
      @api_path = api_path
      @api_params = api_params
    end

    def perform
      uri = URI.parse("https://rubyonring3-dev-ed.my.salesforce.com/services/data/v23.0/#{@api_path}")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{@user_session[:salesforce_access_token]}"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code.to_i == 401
        salesforce_response = SalesForce::Oauth.new.perform
        @user_session[:salesforce_access_token] = salesforce_response['access_token']
        request["Authorization"] = "Bearer #{@user_session[:salesforce_access_token]}"
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
      end

      data = JSON.parse(response.body)
      data['recentItems']
    end
  end
end