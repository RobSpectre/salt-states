log.info("Restoring core configs.")
bot["configs"] = {'Webserver': {'SSL': {'port': 3142, 'certificate': '', 'enabled': False, 'host': '0.0.0.0', 'key': ''}, 'PORT': 3141, 'HOST': '0.0.0.0'}, 'TwilioLookup': {'TWILIO_ACCOUNT_SID': '{{ twilio_account_sid }}', 'TWILIO_AUTH_TOKEN': '{{ twilio_auth_token }}'}}
log.info("Installing plugins.")
for repo in bot["repos"]:
   errors = bot.install(repo)
   for error in errors:
      log.error(error)
log.info("Restoring plugins data.")
pobj = get_plugin_by_name("Plugins").plugin_object
pobj.init_storage()
pobj["repos"] = {}
pobj.close_storage()
