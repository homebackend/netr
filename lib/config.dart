const Map properties = {
  'upgrade': {
    'baseUrls': [
      'http://192.168.1.10/apks/netr'
    ],
    'fileName': 'app-armeabi-v7a-release.apk',
  },
  'defaultImageLocation': 'location1',
  'images': {
    '/location1': {
      'client_id': '<client-id>',
      'key': '<key>',
      'secret': '<secret>',
      'refreshToken':
          '<refresh-token>',
    },
  },
  'ssh': {
    'location1': {
      'host': '<ssh-host>',
      'port': '<ssh-port>',
      'user': '<ssh-user>',
      'privateKey': """
-----BEGIN RSA PRIVATE KEY-----
...................
...................
-----END RSA PRIVATE KEY-----
"""
    },
    'location2': {
      'host': '<ssh-host>',
      'port': '<ssh-port>',
      'user': '<ssh-user>',
      'privateKey': """
-----BEGIN RSA PRIVATE KEY-----
...................
...................
-----END RSA PRIVATE KEY-----
"""
    }
  },
  'cameras': {
    'camera1': {
      'user': '<camera-user>',
      'password': '<camera-password>',
      'default-access-point': 'location2',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          'location1': {
            'host': '<hostname>',
            'port': 554,
          },
          'location2': {
            'host': '<hostname>',
            'port': 55541,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/101?starttime=',
        'access-points': {
          'location1': {
            'host': '<hostname>',
            'port': 554,
          },
          'location2': {
            'host': '<hostname>',
            'port': 55540,
          },
        }
      },
    },
    'camera2': {
      'user': '<camera-user>',
      'password': '<camera-password>',
      'default-access-point': 'location2',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          'location1': {
            'host': '<hostname>',
            'port': 554,
          },
          'location2': {
            'host': '<hostname>',
            'port': 55542,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/201?starttime=',
        'access-points': {
          'location1': {
            'host': '<hostname>',
            'port': 554,
          },
          'location2': {
            'host': '<hostname>',
            'port': 55540,
          },
        }
      }
    }
  },
  'vlc': {
    'host': '<vlc-host>',
    'port': '8080',
    'user': '',
    'password': '<password>',
  },
};
