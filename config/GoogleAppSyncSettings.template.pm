package GoogleAppSyncSettings;

#use Crypt::CBC;
#use MIME::Base64;
#use Digest::MD5 qw(md5_base64);
#use Digest::SHA1 qw(sha1_hex);
#use Data::Dumper;

# Google APPS settings
my $APPS_CONFIG = {
    APPS_OAUTHCONF   => 'config/ouath2service.json',                               # path to the oauth2 configuration and with private key string
    APPS_DOMAIN      => 'mydomain.cz',                                             # primary APPS domain
    APPS_USER        => 'google-admin@mydomain.cz',                                # login with admin permission, all APPS admins are excluded from synchronization
    APPS_CUSTOMER    => 'C12345678',                                               # for orgunits synchronziation
    APPS_MAXRESULTS  => 500,                                                       # maximum is 500 object in single request response
    APPS_TRY_MAX     => 5,                                                         # maximum number of tries for each request
    APPS_UD_OUP      => "/Organization",                                           # default orgunit path for users
    APPS_PASSHASH    => sub { return "11aaaaaabbbbbbbbbbbbbbbbcccccccccccccc99" }, # hash generator
    APPS_VERSHASH    => sub { return "1234567890" },                               # hash timestamp generator (for hash versioning)

};

# LDAP/AD
my $LDAP_CONFIG = {
    LDAP_HOST     => "primary-ad.mydomain.cz",
    LDAP_USER     => "google-apps-sync",
    LDAP_PASSWORD => "mySecretLdapPassword",
};

# LDAP settings
my $LDAP_SEARCH = {
    BASE => 'DC=mydomain,DC=cz',
    DN   => {
	users     => 'CN=ALL-USERS,OU=SYNC',
	groups    => 'OU=ALL-ORGUNITS,OU=SYNC',
	photos    => 'CN=ALL-USERS,OU=SYNC',
    },
    MEMBEROF_TREE_LIMIT => { # ignore memberOf which not match
	users     => 'OU=SYNC,DC=mydomain,DC=cz',
	groups    => 'OU=SYNC,DC=mydomain,DC=cz',
    },
};

sub get_APPS_CONFIG {return $APPS_CONFIG};
sub get_LDAP_CONFIG {return $LDAP_CONFIG};
sub get_LDAP_SEARCH {return $LDAP_SEARCH};

1;
