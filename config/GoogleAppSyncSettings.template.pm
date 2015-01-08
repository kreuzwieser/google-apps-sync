package GoogleAppSyncSettings;

# Google APPS settings
my $APPS_CONFIG = {
    APPS_OAUTHCONF   => 'config/ouath2service.json',
    APPS_DOMAIN      => 'mydomain.cz',
    APPS_USER        => 'google-admin@mydomain.cz',
    APPS_CUSTOMER    => 'C12345678',
    APPS_MAXRESULTS  => 500,
    APPS_TRY_MAX     => 5,
    APPS_UD_OUP      => "/Organization", # default orgunit path for users
    APPS_UD_PASSHASH => "11aaaaaabbbbbbbbbbbbbbbbcccccccccccccc99", # default secret hash for users (SAML2 auth enabled)
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
	orgunits  => 'OU=ALL-ORGUNITS,OU=SYNC',
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
