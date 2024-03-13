import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = AsymmetricBlockCipher('RSA/PKCS1')
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = AsymmetricBlockCipher('RSA/PKCS1')
    ..init(
        false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair({
  SecureRandom? secureRandom,
  int bitLength = 2048,
}) {
  secureRandom ??= exampleSecureRandom();
  // Create an RSA key generator and initialize it
  final keyGen = RSAKeyGenerator()
    ..init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom,
      ),
    );

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom exampleSecureRandom() {
  final secureRandom = FortunaRandom();

  final seedSource = Random.secure();
  final seeds = <int>[];
  for (int i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}

String encodePublicKeyToPemPKIX(RSAPublicKey publicKey) {
  var encodedPublicKey = encodePublicKeyToAsn1SequencePKIX(publicKey);

  encodedPublicKey = encodedPublicKey.replaceAllMapped(
      RegExp(r'.{1,64}'), (match) => '${match.group(0)}\n');

  return '-----BEGIN PUBLIC KEY-----\n$encodedPublicKey-----END PUBLIC KEY-----';
}

String encodePrivateKeyToPemPKCS8(RSAPrivateKey privateKey) {
  var encodePrivateKey = encodePrivateKeyToAsn1SequencePKCS8(privateKey);

  encodePrivateKey = encodePrivateKey.replaceAllMapped(
      RegExp(r'.{1,64}'), (match) => '${match.group(0)}\n');

  return '-----BEGIN PRIVATE KEY-----\n$encodePrivateKey-----END PRIVATE KEY-----';
}

String encodePublicKeyToAsn1SequencePKIX(RSAPublicKey publicKey) {
  final algorithmSeq = ASN1Sequence();
  final algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  final paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  final publicKeySeq = ASN1Sequence();
  publicKeySeq.add(ASN1Integer(publicKey.modulus!));
  publicKeySeq.add(ASN1Integer(publicKey.exponent!));
  final publicKeySeqBitString =
      ASN1BitString(stringValues: publicKeySeq.encode());

  final topLevelSeq = ASN1Sequence();
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqBitString);
  return base64.encode(topLevelSeq.encode());
}

String encodePrivateKeyToAsn1SequencePKCS8(RSAPrivateKey privateKey) {
  final version = ASN1Integer(BigInt.from(0));

  final algorithmSeq = ASN1Sequence();
  final algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  final paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  final privateKeySeq = ASN1Sequence();
  final modulus = ASN1Integer(privateKey.n!);
  final publicExponent = ASN1Integer(BigInt.parse('65537'));
  final privateExponent = ASN1Integer(privateKey.privateExponent!);
  final p = ASN1Integer(privateKey.p!);
  final q = ASN1Integer(privateKey.q!);
  final dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
  final exp1 = ASN1Integer(dP);
  final dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
  final exp2 = ASN1Integer(dQ);
  final iQ = privateKey.q!.modInverse(privateKey.p!);
  final co = ASN1Integer(iQ);

  privateKeySeq.add(version);
  privateKeySeq.add(modulus);
  privateKeySeq.add(publicExponent);
  privateKeySeq.add(privateExponent);
  privateKeySeq.add(p);
  privateKeySeq.add(q);
  privateKeySeq.add(exp1);
  privateKeySeq.add(exp2);
  privateKeySeq.add(co);
  final publicKeySeqOctetString =
      ASN1OctetString(octets: privateKeySeq.encode());
  final topLevelSeq = ASN1Sequence();
  topLevelSeq.add(version);
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqOctetString);
  return base64.encode(topLevelSeq.encode());
}

RSAPrivateKey parsePrivateKeyFromPemPKCS8(String privateKeyString) {
  privateKeyString = privateKeyString
      .replaceAll(RegExp(r'-+(BEGIN|END)( RSA)? PRIVATE KEY-+'), '')
      .replaceAll(RegExp(r'\n'), '')
      .trim();

  List<int> privateKeyDER = base64Decode(privateKeyString);
  var asn1Parser = ASN1Parser(privateKeyDER as Uint8List);
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  final privateKey = topLevelSeq.elements![2];

  asn1Parser = ASN1Parser(privateKey.valueBytes!);
  final pkSeq = asn1Parser.nextObject() as ASN1Sequence;

  final modulus = pkSeq.elements![1] as ASN1Integer;
  final privateExponent = pkSeq.elements![3] as ASN1Integer;
  final p = pkSeq.elements![4] as ASN1Integer;
  final q = pkSeq.elements![5] as ASN1Integer;

  return RSAPrivateKey(
    modulus.integer!,
    privateExponent.integer!,
    p.integer,
    q.integer,
  );
}

RSAPublicKey parsePublicKeyFromPemPKIX(String publicKeyString) {
  publicKeyString = publicKeyString
      .replaceAll(RegExp(r'-+(BEGIN|END) PUBLIC KEY-+'), '')
      .replaceAll(RegExp(r'\n'), '')
      .trim();

  List<int> publicKeyDER = base64Decode(publicKeyString);
  final asn1Parser = ASN1Parser(publicKeyDER as Uint8List);
  final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  final publicKeyBitString = topLevelSeq.elements![1];

  final publicKeyAsn = ASN1Parser(publicKeyBitString.valueBytes!);
  final publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
  final modulus = publicKeySeq.elements![0] as ASN1Integer;
  final exponent = publicKeySeq.elements![1] as ASN1Integer;

  return RSAPublicKey(modulus.integer!, exponent.integer!);
}
