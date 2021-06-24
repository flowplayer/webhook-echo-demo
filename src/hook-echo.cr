require "http/server"
require "openssl/hmac"

module Hook::Echo
  VERSION          = "0.1.0"
  # this is the header that stores the signature flowplayer generates
  # to verify that it hasn't been tampered with in the middle
  SIGNATURE_HEADER = "X-FP-Webhook-Signature-Hmac-Sha-256"
  # fetch the signing secret from environment variables
  SIGNING_SECRET   = ENV["FLOWPLAYER_WEBHOOK_SECRET"]
  # you should probably always put an upperbound on how much
  # data your application is willing to read into memory
  MAX_PAYLOAD      = 2 ** 20
  # verify the remote signature with our locally calculated signature
  def self.verified?(sig, payload)
    calculated = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA256, SIGNING_SECRET, payload)
    puts "--- signature: ---\n%s=%s\ncalculated=%s\n--- ok=%s ---\n" % [SIGNATURE_HEADER, sig, calculated, sig == calculated]
    sig == calculated
  end

  def self.accept(context)
    context.response.status = HTTP::Status::NO_CONTENT
    sig  = context.request.headers[Hook::Echo::SIGNATURE_HEADER]?
    body = self.extract_body(context)
    return no_unicorns(context) unless sig && body
    return signature_mismatch(context) unless self.verified?(sig, body)
    puts "body=%s" % body
  end

  # read the request payload (max 1mb) into memory
  def self.extract_body(context)
    if bod = context.request.body
      bod.gets(MAX_PAYLOAD)
    else
      nil
    end
  end

  # generic 404 message
  def self.no_unicorns(context)
    context.response.respond_with_status(404, "no unicorns found")
  end

  # specific 403 message when the payload signatures do not match
  def self.signature_mismatch(context)
    context.response.respond_with_status(403, "signature mistmatch when verifying payload")
  end

  # simple router that matches:
  #   1. POST -> /
  def self.route(context)
    case [context.request.method, context.request.path]
    when ["POST", "/"] then self.accept(context)
    else self.no_unicorns(context)
    end
  end


  def self.run()
    server = HTTP::Server.new do |context| self.route(context) end
    address = server.bind_tcp 8080
    puts "listening on http://%s" % address
    server.listen
  end

  self.run()
end
