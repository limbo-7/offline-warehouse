-- ODS - ods_user_info_inc - 用户增量表

DROP TABLE IF EXISTS ods_user_info_inc;
CREATE EXTERNAL TABLE ods_user_info_inc
(
    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<id :STRING,
        login_name :STRING,
        nick_name :STRING,
        passwd :STRING,
        name :STRING,
        phone_num :STRING,
        email:STRING,
        head_img :STRING,
        user_level :STRING,
        birthday :STRING,
        gender :STRING,
        create_time :STRING,
        operate_time:STRING,
        status :STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '用户表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
LOCATION '/warehouse/gmall/ods/ods_user_info_inc/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');





load_data(){
    for i in $*; do
            sql=$sql"load data inpath '/origin_data/$APP/db/${i:4}/$do_date' OVERWRITE into table ${APP}.$i partition(dt='$do_date');"
    done
}

        load_data "ods_activity_info_full"
        load_data "ods_activity_rule_full"
        load_data "ods_base_category1_full"
        load_data "ods_base_category2_full"
        load_data "ods_base_category3_full"
        load_data "ods_base_dic_full"
        load_data "ods_base_province_full"
        load_data "ods_base_region_full"
        load_data "ods_base_trademark_full"
        load_data "ods_cart_info_full"
        load_data "ods_coupon_info_full"
        load_data "ods_sku_attr_value_full"
        load_data "ods_sku_info_full"
        load_data "ods_sku_sale_attr_value_full"
        load_data "ods_spu_info_full"
        load_data "ods_promotion_pos_full"
        load_data "ods_promotion_refer_full"

        load_data "ods_cart_info_inc"
        load_data "ods_comment_info_inc"
        load_data "ods_coupon_use_inc"
        load_data "ods_favor_info_inc"
        load_data "ods_order_detail_inc"
        load_data "ods_order_detail_activity_inc"
        load_data "ods_order_detail_coupon_inc"
        load_data "ods_order_info_inc"
        load_data "ods_order_refund_info_inc"
        load_data "ods_order_status_log_inc"
        load_data "ods_payment_info_inc"
        load_data "ods_refund_payment_inc"
        load_data "ods_user_info_inc"
        load_data "ods_activity_info_full" "ods_activity_rule_full" "ods_base_category1_full" "ods_base_category2_full" "ods_base_category3_full" "ods_base_dic_full" "ods_base_province_full" "ods_base_region_full" "ods_base_trademark_full" "ods_cart_info_full" "ods_coupon_info_full" "ods_sku_attr_value_full" "ods_sku_info_full" "ods_sku_sale_attr_value_full" "ods_spu_info_full" "ods_promotion_pos_full" "ods_promotion_refer_full" "ods_cart_info_inc" "ods_comment_info_inc" "ods_coupon_use_inc" "ods_favor_info_inc" "ods_order_detail_inc" "ods_order_detail_activity_inc" "ods_order_detail_coupon_inc" "ods_order_info_inc" "ods_order_refund_info_inc" "ods_order_status_log_inc" "ods_payment_info_inc" "ods_refund_payment_inc" "ods_user_info_inc"
