class TrackingService
    attr_reader :api_key, :tracking_number
  
    def initialize(api_key, tracking_number)
      @api_key = api_key
      @tracking_number = tracking_number
    end
  
    def call
      response = HTTParty.get(
        "https://api.aftership.com/tracking/2024-01/trackings/#{@tracking_number}",
        headers: {
            'Content-Type' => 'application/json',
            'aftership-api-key' => @api_key
        }
      )
  
      response
    end
  end