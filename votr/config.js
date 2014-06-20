var config = {};

config.couchdb = {};
config.twilio = {};

config.couchdb.url = 'http://localhost:5984/database';
config.couchdb.secureUrl = 'http://{{ username }}:{{ password }}@localhost:5984/database';
config.couchdb.secondsToInvalidateEvents = 120;
config.couchdb.secondsToFlushVotes = 0;

config.twilio.sid = '{{ twilio_account_sid }}';
config.twilio.key = '{{ twilio_auth_token }}';
config.twilio.smsWebhook = 'http://votr.brooklynhacker.com/vote/sms';
config.twilio.voiceWebhook = 'http://votr.brooklynhacker.com/vote/voice';
config.twilio.disableSigCheck = true;

config.cookiesecret = 'tOm&atRagEsO!eMhoYDo}CulAsdO^vOr';

module.exports = config;
