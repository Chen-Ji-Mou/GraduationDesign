package com.graduationdesign.backend.controller;

import com.graduationdesign.backend.Result;
import com.graduationdesign.backend.entity.Enterprise;
import com.graduationdesign.backend.entity.Live;
import com.graduationdesign.backend.entity.Product;
import com.graduationdesign.backend.service.IEnterpriseService;
import com.graduationdesign.backend.service.ILiveService;
import com.graduationdesign.backend.service.IProductService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.Nullable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/product")
public class ProductController {

    @Autowired
    IProductService productService;
    @Autowired
    IEnterpriseService enterpriseService;
    @Autowired
    ILiveService liveService;
    @Value("${file.upload.root.path}")
    private String fileRootPath;

    @RequestMapping(value = "/uploadCover", method = RequestMethod.POST)
    private Result uploadCover(@RequestParam("enterpriseId") String enterpriseId, @RequestParam("file") MultipartFile file) {
        Enterprise enterprise = enterpriseService.findEnterpriseById(enterpriseId);
        if (enterprise == null) {
            log.info("[ProductController] uploadCover 商家不存在 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家不存在");
        }
        String fileSuffix = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
        String coverFileName = "cover_" + System.currentTimeMillis() + fileSuffix;
        String coverFilePath = fileRootPath + '/' + coverFileName;
        File coverFile = new File(coverFilePath);
        try {
            // 生成父目录
            if (!coverFile.getParentFile().exists()) {
                coverFile.getParentFile().mkdirs();
            }

            // 覆盖原有文件
            if (coverFile.exists()) {
                coverFile.delete();
                coverFile.createNewFile();
            } else {
                coverFile.createNewFile();
            }

            // 保存视频文件放入本地
            file.transferTo(coverFile);

            log.info("[ProductController] uploadCover 商家产品封面上传成功 enterpriseId {} path {}", enterpriseId, coverFilePath);
            return Result.success(coverFileName);
        } catch (Exception e) {
            e.printStackTrace();
            log.info("[ProductController] uploadCover 商家产品封面上传失败 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家产品封面上传失败");
        }
    }

    @RequestMapping(value = "/downloadCover", method = RequestMethod.GET)
    private void downloadCover(@RequestParam("fileName") String fileName, HttpServletResponse response) throws IOException {
        String coverFilePath = fileRootPath + '/' + fileName;
        File file = new File(coverFilePath);
        if (!file.exists()) {
            log.info("[ProductController] downloadCover 商家产品封面文件不存在 name {}", fileName);
            response.reset();
            response.setStatus(500);
            response.setContentType("application/json");
            response.setCharacterEncoding("utf-8");
            response.getWriter().write("商家产品封面文件不存在");
            return;
        }

        response.reset();
        response.setContentType("application/octet-stream");
        response.setCharacterEncoding("utf-8");
        response.setContentLength((int) file.length());
        response.setHeader("Content-Disposition", "attachment;filename=" + fileName);

        try {
            // 将文件写入输入流
            InputStream fis = new BufferedInputStream(new FileInputStream(file));
            byte[] buffer = new byte[fis.available()];
            fis.read(buffer);
            fis.close();
            // 将文件写入输出流
            OutputStream outputStream = new BufferedOutputStream(response.getOutputStream());
            outputStream.write(buffer);
            outputStream.flush();
            log.info("[ProductController] downloadCover 商家产品封面下载成功 name {}", fileName);
        } catch (IOException e) {
            log.info("[ProductController] downloadCover 商家产品封面下载失败 name {}", fileName);
        }
    }

    @RequestMapping(value = "/addProduct", method = RequestMethod.POST)
    private Result addProduct(@RequestParam("enterpriseId") String enterpriseId, @RequestParam("name") String name, @Nullable @RequestParam("coverUrl") String coverUrl, @Nullable @RequestParam("intro") String intro, @RequestParam("status") Boolean status, @RequestParam("inventory") Integer inventory, @RequestParam("price") Double price) {
        Enterprise enterprise = enterpriseService.findEnterpriseById(enterpriseId);
        if (enterprise == null) {
            log.info("[ProductController] addProduct 商家不存在 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家不存在");
        }
        Product product = new Product();
        String productId = RandomStringUtils.randomNumeric(11);
        product.setId(productId);
        product.setEnterpriseId(enterpriseId);
        product.setName(name);
        product.setCoverUrl(coverUrl);
        product.setIntro(intro);
        product.setStatus(status);
        product.setInventory(inventory);
        product.setPrice(price);
        productService.addProduct(product);
        log.info("[ProductController] addProduct 商家添加商品成功 enterpriseId {} productId {}", enterpriseId, productId);
        return Result.success();
    }

    @RequestMapping(value = "/getEnterpriseProducts", method = RequestMethod.GET)
    private Result getEnterpriseProducts(@RequestParam("enterpriseId") String enterpriseId) {
        Enterprise enterprise = enterpriseService.findEnterpriseById(enterpriseId);
        if (enterprise == null) {
            log.info("[ProductController] getEnterpriseProducts 商家不存在 enterpriseId {}", enterpriseId);
            return Result.failed(500, "商家不存在");
        }
        List<Product> products = productService.findProductsByEnterpriseId(enterpriseId);
        log.info("[ProductController] getEnterpriseProducts 获取商家产品列表成功 enterpriseId {}", enterpriseId);
        return Result.success(products);
    }

    @RequestMapping(value = "/getLiveProducts", method = RequestMethod.GET)
    private Result getLiveProducts(@RequestParam("liveId") String liveId) {
        Live live = liveService.findLiveById(liveId);
        if (live == null) {
            log.info("[ProductController] getLiveProducts 直播间不存在 liveId {}", liveId);
            return Result.failed(500, "直播间不存在");
        }
        String userId = live.getUserId();
        Enterprise enterprise = enterpriseService.findEnterpriseByUserId(userId);
        if (enterprise == null) {
            log.info("[ProductController] getLiveProducts 用户未进行商家认证 userId {}", userId);
            return Result.failed(500, "用户未进行商家认证");
        }
        String enterpriseId = enterpriseService.findEnterpriseByUserId(userId).getId();
        List<Product> products = productService.findProductsByEnterpriseId(enterpriseId);
        log.info("[ProductController] getLiveProducts 获取直播间产品列表成功 liveId {}", liveId);
        return Result.success(products);
    }

    @RequestMapping(value = "/updateProduct", method = RequestMethod.POST)
    private Result updateProduct(@RequestParam("productId") String productId, @Nullable @RequestParam("name") String name, @Nullable @RequestParam("coverUrl") String coverUrl, @Nullable @RequestParam("intro") String intro, @Nullable @RequestParam("status") Boolean status, @Nullable @RequestParam("inventory") Integer inventory, @Nullable @RequestParam("price") Double price) {
        Product product = productService.findProductById(productId);
        if (product == null) {
            log.info("[ProductController] updateProduct 商家产品不存在 productId {}", productId);
            return Result.failed(500, "商家产品不存在");
        }
        if (name != null) {
            product.setName(name);
        }
        if (coverUrl != null) {
            product.setCoverUrl(coverUrl);
        }
        if (intro != null) {
            product.setIntro(intro);
        }
        if (status != null) {
            product.setStatus(status);
        }
        if (inventory != null) {
            product.setInventory(inventory);
        }
        if (price != null) {
            product.setPrice(price);
        }
        productService.updateProductById(productId, product);
        log.info("[ProductController] updateProduct 修改商家产品成功 productId {}", productId);
        return Result.success();
    }

    @RequestMapping(value = "/deleteProduct", method = RequestMethod.POST)
    private Result deleteProduct(@RequestParam("productId") String productId) {
        Product product = productService.findProductById(productId);
        if (product == null) {
            log.info("[ProductController] deleteProduct 商家产品不存在 productId {}", productId);
            return Result.failed(500, "商家产品不存在");
        }
        productService.deleteProductById(productId);
        log.info("[ProductController] deleteProduct 删除商家产品成功 productId {}", productId);
        return Result.success();
    }

    @RequestMapping(value = "/getProductInfo", method = RequestMethod.GET)
    private Result getProductInfo(@RequestParam("productId") String productId) {
        Product product = productService.findProductById(productId);
        if (product == null) {
            log.info("[ProductController] getProductInfo 商家产品不存在 productId {}", productId);
            return Result.failed(500, "商家产品不存在");
        }
        log.info("[ProductController] getProductInfo 获取商家产品成功 productId {}", productId);
        return Result.success(product);
    }
}
