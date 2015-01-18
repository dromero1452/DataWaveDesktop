import ddf.minim.*;

public class FSKModem {

  public AudioInput ain;
  public AudioOutput aout;

  public FSKSignalWave signalWave;
  public FSKSignalAnalyzer signalAnalyzer;

  ///////// copied from Modem //////////////////
  public byte[] readBytes() {
    byte[] bytes = null;
    int size = available();
    if (size > 0) {
      bytes = new byte[size];
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = (byte) read();
      }
    }
    return bytes;
  }

  public void write(byte bytes[]) {
    for (int i = 0; i < bytes.length; i++) {
      write(bytes[i]);
      System.out.println("wrote " + bytes[i]);
    }
  }

  public void write(String what) {
    write(what.getBytes());
  }
  ////////////////////////////////////

  /**
   * a Constructor, usually called in the setup() method in your sketch to
   * initialize and start the library.
   *
   * @param minim
   */
  public FSKModem(Minim minim, float highFreq, float lowFreq, float bitRate,
      float highFreq2, float lowFreq2, float bitRate2) {

    ain = minim.getLineIn(Minim.MONO);
    aout = minim.getLineOut(Minim.MONO);

    signalWave = new FSKSignalWave(highFreq, lowFreq, bitRate,
        aout.sampleRate());
    aout.addSignal(signalWave);

    signalAnalyzer = new FSKSignalAnalyzer(highFreq2, lowFreq2, bitRate2,
        ain.sampleRate(), ain.bufferSize());
    ain.addListener(signalAnalyzer);
  }

  public int available() {
    return signalAnalyzer.available();
  }

  public int read() {
    return signalAnalyzer.read();
  }

  public void write(byte value) {
    signalWave.write(value);
  }

  public void close() {
    ain.close();
    aout.close();
  }

  public void setFreq(float h_freq, float l_freq) {
    signalWave.setFreq(h_freq, l_freq);
  }

  public void setFreq2(float h_freq, float l_freq) {
    float bw = (h_freq - l_freq) / 4;
    setFreq2(h_freq, bw, l_freq, bw);
  }

  public void setFreq2(float h_freq, float h_bw, float l_freq, float l_bw) {
    signalAnalyzer.setFreq(h_freq, h_bw, l_freq, l_bw);
  }
}

