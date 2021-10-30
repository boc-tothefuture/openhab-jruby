const Configuration = {

  extends: ['@commitlint/config-conventional'],

  /*
   * Any rules defined here will override rules from @commitlint/config-conventional
   */
  rules: {
    'footer-max-line-length': [0, 'always', 'Inifinity'],
  },
};

module.exports = Configuration;