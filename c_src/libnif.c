#include <stdbool.h>
#include <stdint.h>
#include <math.h>
#include <erl_nif.h>

void gamma32(uint64_t size, uint8_t *array, double gamma)
{
    double n = 1 / gamma;
    for(uint64_t i = 0; i < size; i++) {
        array[i] = (uint8_t) round(255 * pow((float)array[i] / 255, n) + 0.5) - 1;
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
    ErlNifBinary binary_data;
    if(__builtin_expect(!enif_inspect_binary(env, binary_term, &binary_data), false)) {
        return enif_make_badarg(env);
    }

    double gamma;
    if(__builtin_expect(!enif_get_double(env, argv[2], &gamma), false)) {
        return enif_make_badarg(env);
    }

    // calculate gamma32
    uint8_t *array = (uint8_t *)binary_data.data;
    gamma32(vec_size, array, gamma);

    return enif_make_binary(env, &binary_data);
}

static ErlNifFunc nif_funcs[] = 
{
    {"gamma32_nif", 3, gamma32_nif}
};

ERL_NIF_INIT(Elixir.GammaNif, nif_funcs, NULL, NULL, NULL, NULL)
