/*
 * This file is part of AtomVM.
 *
 * Copyright 2018 Davide Bettio <davide@uninstall.it>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
 */

#ifndef _VALUESHASHTABLE_H_
#define _VALUESHASHTABLE_H_

#ifdef __cplusplus
extern "C" {
#endif

struct ValuesHashTable
{
    int capacity;
    int count;
    struct HNode **buckets;
};

struct ValuesHashTable *valueshashtable_new();
int valueshashtable_insert(struct ValuesHashTable *hash_table, unsigned long key, unsigned long value);
unsigned long valueshashtable_get_value(const struct ValuesHashTable *hash_table, unsigned long key, unsigned long default_value);
int valueshashtable_has_key(const struct ValuesHashTable *hash_table, unsigned long key);

#ifdef __cplusplus
}
#endif

#endif
