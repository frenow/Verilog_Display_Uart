const {SerialPort} = require('serialport');

const tangnano = new SerialPort({
    path: 'COM13',
    baudRate: 115200,
});
var msg = [];
msg = "Say your prayers, little one, don't forget, my son To include ev";

for (i = 0; i<msg.length; i++)
    tangnano.write(Buffer.from(msg[i]));

//console.log('Envia numero '+cont+' para fpga Tang Nano 20k');
tangnano.on('data', function (data) {
    console.log('Data In Text:', data.toString());
    console.log('Data In Hex:', data.toString('hex'));

    const binary = data.toString().split('').map((byte) => {
        return byte.charCodeAt(0).toString(2).padStart(8, '0');
    });
    console.log('Data In Binary: ', binary.join(' '));
  
    //tangnano.write(Buffer.from([cont]));
    //cont++;
    //if (cont > 126)
    //    cont = 32;
});
