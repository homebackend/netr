// All values prefixed with __ need to given right values
// Additionally you will have to change IP addresses and ports
// The URLs are for Hikvision cameras and NVRs. You might have
// modify for other cameras/NVRs.

const Map properties = {
  'upgrade': {
    'baseUrl': 'http://__HOST__/apks/netr',
    'fileName': 'app-armeabi-v7a-release.apk',
  },
  'images': {
    '/__location__': {
      'client_id': '__dropbox_client_id__',
      'key': '__dropbox_key__',
      'secret': '__dropbox_secret__',
    },
  },
  'ssh': {
    '__locartion__': {
      'host': '__public_ip_address__',
      'port': '__ssh_port__',
      'user': '__ssh_user__',
      'privateKey': """
-----BEGIN RSA PRIVATE KEY-----
__SSH_KEY__
-----END RSA PRIVATE KEY-----
"""
    }
  },
  'cameras': {
    '__CAMERA_NAME_1__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.64',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55541,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/101?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_2__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.2',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55542,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/201?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_3__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.7',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55543,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/601?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_4__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.5',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55544,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/401?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_5__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.3',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55545,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/301?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_6__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.6',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55546,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/501?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    '__CAMERA_NAME_7__': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'high': '/Streaming/Channels/101/',
          'low': '/Streaming/Channels/102/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.8',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55547,
          },
        },
      },
      'archive': {
        'path': '/Streaming/tracks/701?starttime=',
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        }
      },
    },
    'channel-zero': {
      'user': '__CAMERA_USER__',
      'password': '__CAMERA_PASSWORD__',
      'default-access-point': '__LOCATION_1__',
      'streams': {
        'paths': {
          'low': '/Streaming/Channels/001/',
        },
        'access-points': {
          '__LOCATION_2__': {
            'host': '192.168.1.4',
            'port': 554,
          },
          '__LOCATION_1__': {
            'host': '192.168.1.13',
            'port': 55540,
          },
        },
      },
    },
  },
  'vlc': {
    'host': '__VLC_HOST__',
    'port': '8080',
    'user': '',
    'password': '__VLC_PASSWORD__',
  },
};
