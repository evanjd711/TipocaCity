module.exports = {
  lintOnSave: false,
  devServer: {
    port: 443,
    https: {
      key: '../key.pem',
      cert: '../cert.pem',
      //ca: fs.readFileSync('./certs/my-ca.crt')
    },
    disableHostCheck: true,
  }
};
