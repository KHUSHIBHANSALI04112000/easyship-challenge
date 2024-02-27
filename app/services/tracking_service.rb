# app/services/tracking_service.rb
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

    handle_response(response)
  end

  private

  def handle_response(response)
    case response.code
    when 200
      render_successful_tracking_response(JSON.parse(response.body))
    when 404
      render_error_response(I18n.t('errors.tracking_not_found.code'), I18n.t('errors.tracking_not_found.message'), I18n.t('errors.tracking_not_found.type'))
    when 500
      render_error_response(I18n.t('errors.internal_server_error.code'),I18n.t('errors.internal_server_error.message'), I18n.t('errors.internal_server_error.type'))
    end
  end

  def render_successful_tracking_response(result)
    if result["data"] && result["data"]["tracking"] && result["data"]["tracking"]["checkpoints"]
      last_checkpoint = result["data"]["tracking"]["checkpoints"][-1]
      
      if last_checkpoint
        status = result["data"]["tracking"]["tag"]
        current_location = last_checkpoint["location"]
        last_checkpoint_message = last_checkpoint["message"]
        last_checkpoint_time = DateTime.parse(last_checkpoint["checkpoint_time"].to_s).strftime("%Y %B %d at %I:%M %p (%A)")
    
        {
          status: status,
          current_location: current_location,
          last_checkpoint_message: last_checkpoint_message,
          last_checkpoint_time: last_checkpoint_time
        }
      else
        { error: "No checkpoints found" }
      end
    else
      { error: "Data not found" }
    end
    
    
  end

  def render_error_response(code, message, type)
    {
      meta: {
        code: code,
        message: message,
        type: type
      }
    }
  end
end
