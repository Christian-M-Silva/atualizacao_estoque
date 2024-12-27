DROP PROCEDURE `estoque`.`atualizar_estoque`;
DELIMITER $$
	CREATE PROCEDURE atualizar_estoque (IN id_product INT, IN month_year VARCHAR(25), OUT out_processes INT)
	BEGIN
		DECLARE current_quantity INT DEFAULT 0;
		DECLARE in_quantity INT DEFAULT 0;
		DECLARE out_quantity INT DEFAULT 0;
		DECLARE quantity_movement INT DEFAULT 0;
		DECLARE critical INT DEFAULT 0;
        DECLARE done BOOLEAN DEFAULT FALSE;
        DECLARE quantities_movement CURSOR FOR SELECT quantidade FROM movimentacoes_estoque WHERE produto_id = id_product AND MONTH(CONCAT(month_year, '-01')) = MONTH(data_movimentacao) AND YEAR(CONCAT(month_year, '-01')) = YEAR(data_movimentacao);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		SET out_processes = 0;
        SELECT quantidade_atual INTO current_quantity FROM produtos WHERE id = id_product;
        
        OPEN quantities_movement;
			process_loop: LOOP
				FETCH quantities_movement INTO quantity_movement;
                IF done THEN
					LEAVE process_loop;
				END IF;
                
                IF quantity_movement > 0 THEN
					SET in_quantity = in_quantity + quantity_movement;
                ELSE
					SET out_quantity = out_quantity - quantity_movement;
                END IF;
                
                SET out_processes = out_processes + 1;
            END LOOP;
        CLOSE quantities_movement;
        
        SET current_quantity = current_quantity + in_quantity - out_quantity;
        
        IF current_quantity < 10 THEN
			SET critical = 1;
		END IF;
        
        UPDATE produtos SET quantidade_atual = current_quantity, estoque_critico = critical WHERE id = id_product;
	END $$
DELIMITER ;