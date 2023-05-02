package com.graduationdesign.backend.service.impl;

import com.graduationdesign.backend.entity.Product;
import com.graduationdesign.backend.mapper.ProductMapper;
import com.graduationdesign.backend.service.IProductService;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.util.List;

@Service
public class ProductServiceImpl implements IProductService {

    @Resource
    ProductMapper mapper;

    @Override
    public void addProduct(Product product) {
        mapper.addProduct(product);
    }

    @Override
    public List<Product> findProductsByEnterpriseId(String enterpriseId) {
        return mapper.findProductsByEnterpriseId(enterpriseId);
    }

    @Override
    public void updateProductById(String id, Product product) {
        mapper.updateProductById(id, product);
    }

    @Override
    public void deleteProductById(String id) {
        mapper.deleteProductById(id);
    }

    @Override
    public Product findProductById(String id) {
        return mapper.findProductById(id);
    }
}
