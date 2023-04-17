package com.graduationdesign.backend;

import java.util.LinkedHashMap;

public class LRUCache<K, V> {
    private final int capacity;
    private final LinkedHashMap<K, V> cache;

    public LRUCache(int capacity) {
        this.capacity = capacity;
        cache = new LinkedHashMap<>();
    }

    public synchronized V get(K key) {
        V value = cache.get(key);
        cache.remove(key);
        cache.put(key, value);
        return value;
    }

    public synchronized V put(K key, V value) {
        cache.remove(key);
        cache.put(key, value);
        V deleteValue = null;
        if (cache.size() > capacity) {
            K first = cache.keySet().iterator().next();
            deleteValue = cache.remove(first);
        }
        return deleteValue;
    }
}
