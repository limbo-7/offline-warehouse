-- ODS - ods_refund_payment_inc - 退款增量表

DROP TABLE IF EXISTS ods_refund_payment_inc;
CREATE EXTERNAL TABLE ods_refund_payment_inc
(
    `type` STRING COMMENT '变动类型',
    `ts`   BIGINT COMMENT '变动时间',
    `data` STRUCT<id :STRING,
        out_trade_no :STRING,
        order_id :STRING,
        sku_id :STRING,
        payment_type :STRING,
        trade_no :STRING,
        total_amount:DECIMAL(16, 2),
        subject :STRING,
        refund_status :STRING,
        create_time :STRING,
        callback_time :STRING,
        callback_content:STRING,
        operate_time :STRING> COMMENT '数据',
    `old`  MAP<STRING,STRING> COMMENT '旧值'
) COMMENT '退款表'
    PARTITIONED BY (`dt` STRING)
    ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.JsonSerDe'
LOCATION '/warehouse/gmall/ods/ods_refund_payment_inc/'
TBLPROPERTIES ('compression.codec'='org.apache.hadoop.io.compress.GzipCodec');
