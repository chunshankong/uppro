package stage1;


import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.time.StopWatch;

import javax.crypto.Cipher;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.HashMap;
import java.util.Map;

public class Task1 {

    public static void main(String[] args) throws Exception {

        step1();
        step2();
    }

    /*
    * ❖ 实践 POW ⽤⾃⼰的昵称 + nonce， 不断的 sha256 Hash :
❖ 直到满⾜ 4个0开头，打印出花费的时间
❖ 直到满⾜ 5个0开头，打印出花费的时间
    * */
    private static void step1() throws NoSuchAlgorithmException {
        //        System.out.println(countZeroStart("023"));
        StopWatch stopWatch1 = new StopWatch();
        stopWatch1.start();
        System.err.println(hashValue("听懂", 4));
        stopWatch1.split();
        stopWatch1.stop();
        System.err.println("4个0耗时：" + stopWatch1.getSplitTime());

        StopWatch stopWatch2 = new StopWatch();
        stopWatch2.start();
        System.err.println(hashValue("听懂", 5));
        stopWatch2.split();
        stopWatch2.stop();
        System.err.println("5个0耗时：" + stopWatch2.getSplitTime());
    }

    /*
* ❖ 实践⾮对称加密 RSA
❖ 先⽣成⼀个公私钥对
❖ ⽤私钥对符合POW⼀个昵称 + nonce 进⾏私钥签名
❖ ⽤公钥验证
* */
    private static void step2() throws Exception {

        //生成公钥和私钥
        getKeyPair();
        //加密字符串
        String data = "听懂";
        String value = hashValue(data, 4);
        System.out.println("数据hash值为：" + value);
        System.out.println("随机生成的公钥为：" + keyMap.get(0));
        System.out.println("随机生成的私钥为：" + keyMap.get(1));
        String passwordEn = encrypt(value, keyMap.get(0));
        System.out.println(value + "\t签名后的hash值摘要为：" + passwordEn);

        //验证数据签名是否一致
        String passwordDe = decrypt(passwordEn, keyMap.get(1));
        System.out.println("还原后的数据hash值为：" + passwordDe);
        String hashValue = hashValue("听懂1", 4);
        if (passwordDe.equals(hashValue)) {
            System.err.println("签名验证通过");
        }
    }

    private static String hashValue(String nickName, int zeroCount) throws NoSuchAlgorithmException {
        String value = null;
        int nonce = 0;
        do {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            // Change this to UTF-16 if needed
            md.update((nickName + nonce).getBytes(StandardCharsets.UTF_8));
            byte[] digest = md.digest();
            String hex = String.format("%064x", new BigInteger(1, digest));
            value = hex;
            nonce++;
        } while (zeroCount > countZeroStart(value));

        return value;
    }

    private static int countZeroStart(String str) {
        int count = 0;
        for (int i = 0; i < str.length() && '0' == (str.charAt(i)); i++) {
            count++;
        }
        return count;
    }


    private static Map<Integer, String> keyMap = new HashMap<>();

    /**
     * 随机生成密钥对
     *
     * @throws NoSuchAlgorithmException
     */
    public static void getKeyPair() throws Exception {
        //KeyPairGenerator类用于生成公钥和密钥对，基于RSA算法生成对象
        KeyPairGenerator keyPairGen = KeyPairGenerator.getInstance("RSA");
        //初始化密钥对生成器，密钥大小为96-1024位
        keyPairGen.initialize(1024, new SecureRandom());
        //生成一个密钥对，保存在keyPair中
        KeyPair keyPair = keyPairGen.generateKeyPair();
        PrivateKey privateKey = keyPair.getPrivate();//得到私钥
        PublicKey publicKey = keyPair.getPublic();//得到公钥
        //得到公钥字符串
        String publicKeyString = new String(Base64.encodeBase64(publicKey.getEncoded()));
        //得到私钥字符串
        String privateKeyString = new String(Base64.encodeBase64(privateKey.getEncoded()));
        //将公钥和私钥保存到Map
        keyMap.put(0, publicKeyString);//0表示公钥
        keyMap.put(1, privateKeyString);//1表示私钥
    }

    /**
     * RSA公钥加密
     *
     * @param str       加密字符串
     * @param publicKey 公钥
     * @return 密文
     * @throws Exception 加密过程中的异常信息
     */
    public static String encrypt(String str, String publicKey) throws Exception {
        //base64编码的公钥
        byte[] decoded = Base64.decodeBase64(publicKey);
        RSAPublicKey pubKey = (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(decoded));
        //RAS加密
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.ENCRYPT_MODE, pubKey);
        String outStr = Base64.encodeBase64String(cipher.doFinal(str.getBytes("UTF-8")));
        return outStr;
    }

    /**
     * RSA私钥解密
     *
     * @param str        加密字符串
     * @param privateKey 私钥
     * @return 铭文
     * @throws Exception 解密过程中的异常信息
     */
    public static String decrypt(String str, String privateKey) throws Exception {
        //Base64解码加密后的字符串
        byte[] inputByte = Base64.decodeBase64(str.getBytes(StandardCharsets.UTF_8));
        //Base64编码的私钥
        byte[] decoded = Base64.decodeBase64(privateKey);
        PrivateKey priKey = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(decoded));
        //RSA解密
        Cipher cipher = javax.crypto.Cipher.getInstance("RSA");
        cipher.init(Cipher.DECRYPT_MODE, priKey);
        return new String(cipher.doFinal(inputByte));

    }
}



