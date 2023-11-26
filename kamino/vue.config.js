module.exports = {
  lintOnSave: false,
  devServer: {
    port: 443,
    https: {
      key: './tls/key.pem',
      cert: './tls/cert.pem',
      //ca: fs.readFileSync('./certs/my-ca.crt')
    },
    disableHostCheck: true,
  }
};
