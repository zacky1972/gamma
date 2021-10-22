#include <stdbool.h>
#include <stdint.h>
#include <math.h>
#include <erl_nif.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

float ipower(float x, int n)
{
  int abs_n;
  float r;

  abs_n =abs(n); r = 1;
  while(abs_n != 0){
    if(abs_n & 1) r *= x;
    x *= x; abs_n >>= 1;
    }
    if(n >= 0) return r; else return 1 / r;
}

float power(float x, float y)
{
  if(y <= INT_MAX && y >= -INT_MAX && y == (int)y)
    return ipower(x, y);
  if(x > 0)
    return expf(y * logf(x));
  if(x != 0 || y <= 0)
    enif_fprintf(stderr, "power: domain error\n");
  return 0;
}

//pow関数を使った時
void gamma32(uint64_t size, uint8_t *in, uint8_t *out, double gamma)
{
    float n = 1 / gamma;
    for(uint64_t i = 0; i < size; i++) {
        out[i] = (uint8_t) round(255 * powf((float)in[i] / 255, n) + 0.5) - 1;
    }
}

//累乗の式を最適化した時
void gamma32p(uint64_t size, uint8_t *in, uint8_t *out, double gamma)
{
    float n = 1 / gamma;
    for(uint64_t i = 0; i < size; i++) {
        out[i] = (uint8_t) round(255 * power((float)in[i] / 255, n) + 0.5) - 1;
    }
}

static ERL_NIF_TERM gamma32_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 3, false)) {
        return enif_make_badarg(env);
    }
    ErlNifUInt64 vec_size;
    if(__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary_term = argv[1];
    ErlNifBinary in_data;
    if(__builtin_expect(!enif_inspect_binary(env, binary_term, &in_data), false)) {
        return enif_make_badarg(env);
    }

    double gamma;
    if(__builtin_expect(!enif_get_double(env, argv[2], &gamma), false)) {
        return enif_make_badarg(env);
    }

    // calculate gamma32
    uint8_t *in = (uint8_t *)in_data.data;
    ErlNifBinary out_data;
    if(__builtin_expect(!enif_alloc_binary(vec_size, &out_data), false)) {
        return enif_make_badarg(env);
    }
    uint8_t *out = (uint8_t *)out_data.data;
    gamma32(vec_size, in, out, gamma);

    return enif_make_binary(env, &out_data);
}

static ERL_NIF_TERM gamma32p_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 3, false)) {
        return enif_make_badarg(env);
    }
    ErlNifUInt64 vec_size;
    if(__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary_term = argv[1];
    ErlNifBinary in_data;
    if(__builtin_expect(!enif_inspect_binary(env, binary_term, &in_data), false)) {
        return enif_make_badarg(env);
    }

    double gamma;
    if(__builtin_expect(!enif_get_double(env, argv[2], &gamma), false)) {
        return enif_make_badarg(env);
    }

    // calculate gamma32p
    uint8_t *in = (uint8_t *)in_data.data;
    ErlNifBinary out_data;
    if(__builtin_expect(!enif_alloc_binary(vec_size, &out_data), false)) {
        return enif_make_badarg(env);
    }
    uint8_t *out = (uint8_t *)out_data.data;
    gamma32p(vec_size, in, out, gamma);

    return enif_make_binary(env, &out_data);
}

static ErlNifFunc nif_funcs[] =
{
    {"gamma32_nif", 3, gamma32_nif},
    {"gamma32p_nif", 3, gamma32p_nif}
};

ERL_NIF_INIT(Elixir.GammaNif, nif_funcs, NULL, NULL, NULL, NULL)
