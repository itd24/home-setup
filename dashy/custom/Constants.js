// Dashy custom config. The API credentials are read from the build-time
// environment (VUE_APP_API_USER / VUE_APP_API_KEY) so that no key ends up in git.
export default {
  authenticationHeaders: {
    'x-api-user': process.env.VUE_APP_API_USER || 'system.user@local.local',
    'x-api-key': process.env.VUE_APP_API_KEY || '',
  },
};
