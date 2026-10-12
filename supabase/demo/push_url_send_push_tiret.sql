-- Adresse de la fonction d'envoi des notifications : elle a été déployée sous
-- le nom « send-push- » (avec un tiret final).
update app_private.push_settings
   set function_url = 'https://xpthqtcjqkpticezglbv.supabase.co/functions/v1/send-push-';
select function_url from app_private.push_settings;
