package com.graduationdesign.backend.mapper;

import com.graduationdesign.backend.entity.Product;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface ProductMapper {
    @Insert("INSERT INTO product(id, enterpriseId, name, coverUrl, intro, status, inventory) VALUES(#{id}, #{enterpriseId}, #{name}, #{coverUrl}, #{intro}, #{status}, #{inventory})")
    void addProduct(Product product);

    @Select("SELECT * FROM product WHERE enterpriseId=#{enterpriseId}")
    List<Product> findProductsByEnterpriseId(String enterpriseId);

    @Update("UPDATE product SET name=#{product.name},coverUrl=#{product.coverUrl},intro=#{product.intro},status=#{product.status},inventory=#{inventory} WHERE id=#{id}")
    void updateProductById(@Param("id") String id, @Param("product") Product product);

    @Delete("DELETE FROM product WHERE id=#{id}")
    void deleteProductById(String id);

    @Select("SELECT * FROM product WHERE id=#{id}")
    Product findProductById(String id);
}
