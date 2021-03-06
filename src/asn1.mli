module RSA :
sig
  module Params :
  sig
    type t = unit
    val grammar : t Asn.t
  end

  module Public :
  sig
    type t = {
      n: Z.t;
      e: Z.t;
    }

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end

  module Private :
  sig
    type other_prime = {
        r: Z.t;
        d: Z.t;
        t: Z.t;
    }

    type t = {
      n: Z.t;
      e: Z.t;
      d: Z.t;
      p: Z.t;
      q: Z.t;
      dp: Z.t;
      dq: Z.t;
      qinv: Z.t;
      other_primes: other_prime list;
    }

    val other_prime_grammar : other_prime Asn.t
    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end
end

module DSA :
sig
  module Params :
  sig
    type t = {
      p: Z.t;
      q: Z.t;
      g: Z.t;
    }

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end

  module Public :
  sig
    type t = Z.t

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end

  module Private :
  sig
    type t = Z.t

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end
end

module EC :
sig
  type point = Cstruct.t
    [@@deriving ord,show,yojson]

  val point_grammar : point Asn.t

  module Field :
  sig
    type basis =
      | GN
      | TP of Z.t
      | PP of Z.t * Z.t * Z.t

    val basis_grammar : basis Asn.t

    type characteristic_two_params = {
      m: Z.t;
      basis: basis;
    }

    val ctwo_params_grammar : characteristic_two_params Asn.t

    type t =
      | Prime of Z.t
      | C_two of characteristic_two_params

    val grammar : t Asn.t
  end

  module Specified_domain :
  sig
    type field_element = Cstruct.t
    val field_element_grammar : field_element Asn.t

    type curve = {
      a: field_element;
      b: field_element;
      seed: Cstruct.t option;
    }

    val curve_grammar : curve Asn.t

    type t = {
      field: Field.t;
      curve: curve;
      base: point;
      order: Z.t;
      cofactor: Z.t option;
    }
      [@@deriving ord,show,yojson]

    val grammar : t Asn.t
  end

  module Params :
  sig
    type t =
      | Named of Asn.OID.t
      | Implicit
      | Specified of Specified_domain.t
      [@@deriving ord,show,yojson]

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end

  module Public :
  sig
    type t = point
      [@@deriving ord,show]

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end

  module Private :
  sig
    type t = {
      k: Cstruct.t;
      params: Params.t option;
      public_key: Public.t option;
    }
      [@@deriving ord,show]

    val grammar : t Asn.t

    val encode : t -> Cstruct.t
    val decode : Cstruct.t -> (t, string) Result.result
  end
end

module Algorithm_identifier :
sig
  val rsa_grammar : RSA.Params.t Asn.t
  val dsa_grammar : DSA.Params.t Asn.t
  val ec_grammar : EC.Params.t Asn.t
end

module X509 :
sig
  type t =
    [ `RSA of RSA.Public.t
    | `DSA of DSA.Params.t * DSA.Public.t
    | `EC of EC.Params.t * EC.Public.t
    ]

  val rsa_grammar : RSA.Public.t Asn.t
  val dsa_grammar : (DSA.Params.t * DSA.Public.t) Asn.t
  val ec_grammar : (EC.Params.t * EC.Public.t) Asn.t

  val encode : t -> Cstruct.t
  val encode_rsa : RSA.Public.t -> Cstruct.t
  val encode_dsa : (DSA.Params.t * DSA.Public.t) -> Cstruct.t
  val encode_ec : (EC.Params.t * EC.Public.t) -> Cstruct.t
  val decode : Cstruct.t -> (t, string) Result.result
  val decode_rsa : Cstruct.t -> (RSA.Public.t, string) Result.result
  val decode_dsa : Cstruct.t -> ((DSA.Params.t * DSA.Public.t), string) Result.result
  val decode_ec : Cstruct.t -> ((EC.Params.t * EC.Public.t), string) Result.result
end

module PKCS8 :
sig
  type t =
    [ `RSA of RSA.Private.t
    | `DSA of DSA.Params.t * DSA.Private.t
    | `EC of EC.Params.t * EC.Private.t
    ]

  val rsa_grammar : RSA.Private.t Asn.t
  val dsa_grammar : (DSA.Params.t * DSA.Private.t) Asn.t
  val ec_grammar : (EC.Params.t * EC.Private.t) Asn.t

  val encode : t -> Cstruct.t
  val encode_rsa : RSA.Private.t -> Cstruct.t
  val encode_dsa : (DSA.Params.t * DSA.Private.t) -> Cstruct.t
  val encode_ec : (EC.Params.t * EC.Private.t) -> Cstruct.t
  val decode : Cstruct.t -> (t, string) Result.result
  val decode_rsa : Cstruct.t -> (RSA.Private.t, string) Result.result
  val decode_dsa : Cstruct.t -> ((DSA.Params.t * DSA.Private.t), string) Result.result
  val decode_ec : Cstruct.t -> ((EC.Params.t * EC.Private.t), string) Result.result
end
