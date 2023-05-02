package com.graduationdesign.backend.service;

import com.graduationdesign.backend.entity.Product;
import java.util.List;

public interface IProductService {
    void addProduct(Product product);
    List<Product> findProductsByEnterpriseId(String enterpriseId);
    void updateProductById(String id, Product product);
    void deleteProductById(String id);
    Product findProductById(String id);
}
